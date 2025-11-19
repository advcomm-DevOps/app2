#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_COPYDATA: {
      // Handle deep link from another instance
      COPYDATASTRUCT* cds = (COPYDATASTRUCT*)lparam;
      if (cds->dwData == 1 && flutter_controller_) {
        std::wstring wcommand_line((wchar_t*)cds->lpData, cds->cbData / sizeof(wchar_t));
        
        // Remove null terminators
        while (!wcommand_line.empty() && wcommand_line.back() == L'\0') {
          wcommand_line.pop_back();
        }
        
        if (wcommand_line.empty()) {
          return TRUE;
        }
        
        // Convert to UTF-8
        int size_needed = WideCharToMultiByte(CP_UTF8, 0, wcommand_line.c_str(), 
                                             (int)wcommand_line.length(), NULL, 0, NULL, NULL);
        if (size_needed <= 0) {
          return TRUE;
        }
        
        std::string command_line(size_needed, 0);
        WideCharToMultiByte(CP_UTF8, 0, wcommand_line.c_str(), (int)wcommand_line.length(),
                           &command_line[0], size_needed, NULL, NULL);
        
        // Send to Flutter via method channel
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            flutter_controller_->engine()->messenger(),
            "xdoc.app/deep_link",
            &flutter::StandardMethodCodec::GetInstance());
        
        flutter::EncodableMap args;
        args[flutter::EncodableValue("url")] = flutter::EncodableValue(command_line);
        
        channel->InvokeMethod("handleDeepLink",
                            std::make_unique<flutter::EncodableValue>(args));
      }
      return TRUE;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
