#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Single instance check
  HANDLE mutex = CreateMutex(NULL, TRUE, L"XDocSingleInstanceMutex");
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    // App is already running, send the deep link to existing instance
    HWND existingWindow = FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"XDoc");
    if (existingWindow != NULL) {
      // Restore if minimized
      if (IsIconic(existingWindow)) {
        ShowWindow(existingWindow, SW_RESTORE);
      }
      // Bring to front
      SetForegroundWindow(existingWindow);
      
      // Send command line (deep link) to existing instance
      if (command_line != NULL && wcslen(command_line) > 0) {
        COPYDATASTRUCT cds;
        cds.dwData = 1; // Custom identifier for deep link
        cds.cbData = (wcslen(command_line) + 1) * sizeof(wchar_t);
        cds.lpData = command_line;
        SendMessage(existingWindow, WM_COPYDATA, (WPARAM)NULL, (LPARAM)&cds);
      }
    }
    if (mutex) {
      CloseHandle(mutex);
    }
    return 0;
  }
  
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"XDoc", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Clean up mutex
  if (mutex) {
    CloseHandle(mutex);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
