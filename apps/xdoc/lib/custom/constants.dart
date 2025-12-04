const String authUrl = 'https://auth.xdoc.app';
final String audDomain =
    const String.fromEnvironment('FLAVOR', defaultValue: 'dev') == 'production'
    ? 'api.xdoc.app'
    : 't.api.xdoc.app';
