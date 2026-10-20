class AppVersion{
  String version_ios;
  String version_android;

  AppVersion({
    required this.version_ios,
    required this.version_android,
    });

    AppVersion.fromMap(Map<String,dynamic> map)
    : version_ios = map['version_ios'],
      version_android = map['version_android'];

    @override
    String toString(){
      return "Versão Android: $version_android\nVersão IOS: $version_ios";
    }

    Map<String, dynamic> toMap() {
      return {
        'version_ios': version_ios,
        'version_android': version_android,
      };
    }
}