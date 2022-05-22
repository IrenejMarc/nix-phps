nixpkgs:

# These are older versions of PHP removed from Nixpkgs.

final:
prev:

let
  packageOverrides = import ./package-overrides.nix prev;

  _mkArgs =
    args:

    {
      inherit packageOverrides;

      # For passing pcre2 to generic.nix.
      pcre2 =
        if prev.lib.versionAtLeast args.version "7.3"
        then prev.pcre2
        else prev.pcre;

      phpAttrsOverrides =
        attrs:

        {
          patches =
            attrs.patches or []
            ++ prev.lib.optionals (prev.lib.versions.majorMinor args.version == "7.2") [
              # Building the bundled intl extension fails on Mac OS.
              # See https://bugs.php.net/bug.php?id=76826 for more information.
              (prev.pkgs.fetchpatch {
                url = "https://bugs.php.net/patch-display.php?bug_id=76826&patch=bug76826.poc.0.patch&revision=1538723399&download=1";
                sha256 = "aW+MW9Kb8N/yBO7MdqZMZzgMSF7b+IMLulJKgKPWrUA=";
              })
            ]
            ++ prev.lib.optionals (prev.lib.versions.majorMinor args.version == "5.6") [
              (prev.pkgs.fetchpatch {
                url = "https://github.com/php/php-src/commit/8c8679207ae5ada8751288e75b78c928a4d34d1d.patch";
                sha256 = "a3c70f5371397885af3ea0772e873c9630eaadb30f49f4a175212a6bef0123b0";
              })
            ];

          configureFlags =
            attrs.configureFlags
            ++ prev.lib.optionals (prev.lib.versionOlder args.version "7.4") [
              # phar extension’s build system expects hash or it will degrade.
              "--enable-hash"

              "--enable-libxml"
              "--with-libxml-dir=${prev.libxml2.dev}"
            ];

          preConfigure =
            prev.lib.optionalString (prev.lib.versionOlder args.version "7.4") ''
              # Workaround “configure: error: Your system does not support systemd.”
              # caused by PHP build system expecting PKG_CONFIG variable to contain
              # an absolute path on PHP ≤ 7.4.
              # Also patches acinclude.m4, which ends up being used by extensions.
              # https://github.com/NixOS/nixpkgs/pull/90249
              for i in $(find . -type f -name "*.m4"); do
                substituteInPlace $i \
                  --replace 'test -x "$PKG_CONFIG"' 'type -P "$PKG_CONFIG" >/dev/null'
              done
            ''
            + attrs.preConfigure;
        };

      # For passing pcre2 to php-packages.nix.
      callPackage =
        cpFn:
        cpArgs:

        prev.callPackage
          cpFn
          (
            cpArgs
            // {
              pcre2 =
                if prev.lib.versionAtLeast args.version "7.3"
                then prev.pcre2
                else prev.pcre;

              # For passing pcre2 to stuff called with callPackage in php-packages.nix.
              pkgs =
                prev
                // (
                  prev.lib.makeScope
                    prev.newScope
                    (self: {
                      pcre2 =
                        if prev.lib.versionAtLeast args.version "7.3"
                        then prev.pcre2
                        else prev.pcre;
                    })
                );
            }
          );
    }
    // args;

  generic = "${nixpkgs}/pkgs/development/interpreters/php/generic.nix";

  base56 = prev.callPackage generic (_mkArgs {
    version = "5.6.40";
    sha256 = "/9Al00YjVTqy9/2Psh0Mnm+fow3FZcoDode3YwI/ugA=";
  });

  base70 = prev.callPackage generic (_mkArgs {
    version = "7.0.33";
    sha256 = "STPqdCmKG6BGsCRv43cUFchN+4eDliAbVstTM6vobwc=";
  });

  base71 = prev.callPackage generic (_mkArgs {
    version = "7.1.33";
    sha256 = "laXl8uK3mzdrc3qC2WgskYkeYCifokGDRjoqyhWPT0s=";
  });

  base72 = prev.callPackage generic (_mkArgs {
    version = "7.2.34";
    sha256 = "DlgW1miiuxSspozvjEMEML2Gw8UjP2xCfRpUqsEnq88=";
  });

  base73 = prev.callPackage generic (_mkArgs {
    version = "7.3.28";
    sha256 = "0r4r8famg3a8x6ch24y1370nsphkxg4k9zq5x8v88f4l8mj6wqwg";

    extraPatches =
      prev.lib.optionals prev.stdenv.isDarwin [
        # Fix build on Darwin
        # https://bugs.php.net/bug.php?id=76826
        (prev.fetchurl {
          url = "https://github.com/NixOS/nixpkgs/raw/42e9a2ccfab2a96d28c3c164a6cf41fb6f769de5/pkgs/development/interpreters/php/php73-darwin-isfinite.patch";
          sha256 = "V0mLLmXa2qJyxIVW/7nEml6cXZTBbr42kkJiij9KPyk=";
        })
      ];
  });
in {
  php56 =
    base56.withExtensions (
      { all, ... }:

      with all; (
        [
          bcmath
          calendar
          curl
          ctype
          dom
          exif
          fileinfo
          filter
          ftp
          gd
          gettext
          gmp
          iconv
          intl
          json
          ldap
          mbstring
          mysqli
          mysqlnd
          opcache
          openssl
          pcntl
          pdo
          pdo_mysql
          pdo_odbc
          pdo_pgsql
          pdo_sqlite
          pgsql
          posix
          readline
          session
          simplexml
          sockets
          soap
          sqlite3
          tokenizer
          xmlreader
          xmlwriter
          zip
          zlib
        ]
        ++ prev.lib.optionals (!prev.stdenv.isDarwin) [
          imap
        ]
      )
    );

  php70 =
    base70.withExtensions (
      { all, ... }:

      with all; (
        [
          bcmath
          calendar
          curl
          ctype
          dom
          exif
          fileinfo
          filter
          ftp
          gd
          gettext
          gmp
          iconv
          intl
          json
          ldap
          mbstring
          mysqli
          mysqlnd
          opcache
          openssl
          pcntl
          pdo
          pdo_mysql
          pdo_odbc
          pdo_pgsql
          pdo_sqlite
          pgsql
          posix
          readline
          session
          simplexml
          sockets
          soap
          sqlite3
          tokenizer
          xmlreader
          xmlwriter
          zip
          zlib
        ]
        ++ prev.lib.optionals (!prev.stdenv.isDarwin) [
          imap
        ]
      )
    );

  php71 =
    base71.withExtensions (
      { all, ... }:

      with all; (
        [
          bcmath
          calendar
          curl
          ctype
          dom
          exif
          fileinfo
          filter
          ftp
          gd
          gettext
          gmp
          iconv
          intl
          json
          ldap
          mbstring
          mysqli
          mysqlnd
          opcache
          openssl
          pcntl
          pdo
          pdo_mysql
          pdo_odbc
          pdo_pgsql
          pdo_sqlite
          pgsql
          posix
          readline
          session
          simplexml
          sockets
          soap
          sqlite3
          tokenizer
          xmlreader
          xmlwriter
          zip
          zlib
        ]
        ++ prev.lib.optionals (!prev.stdenv.isDarwin) [
          imap
        ]
      )
    );

  php72 =
    base72.withExtensions (
      { all, ... }:

      with all; (
        [
          bcmath
          calendar
          curl
          ctype
          dom
          exif
          fileinfo
          filter
          ftp
          gd
          gettext
          gmp
          iconv
          intl
          json
          ldap
          mbstring
          mysqli
          mysqlnd
          opcache
          openssl
          pcntl
          pdo
          pdo_mysql
          pdo_odbc
          pdo_pgsql
          pdo_sqlite
          pgsql
          posix
          readline
          session
          simplexml
          sockets
          soap
          sodium
          sqlite3
          tokenizer
          xmlreader
          xmlwriter
          zip
          zlib
        ]
        ++ prev.lib.optionals (!prev.stdenv.isDarwin) [
          imap
        ]
      )
    );

  php73 =
    base73.withExtensions (
      { all, ... }:

      with all; (
        [
          bcmath
          calendar
          curl
          ctype
          dom
          exif
          fileinfo
          filter
          ftp
          gd
          gettext
          gmp
          iconv
          intl
          json
          ldap
          mbstring
          mysqli
          mysqlnd
          opcache
          openssl
          pcntl
          pdo
          pdo_mysql
          pdo_odbc
          pdo_pgsql
          pdo_sqlite
          pgsql
          posix
          readline
          session
          simplexml
          sockets
          soap
          sodium
          sqlite3
          tokenizer
          xmlreader
          xmlwriter
          zip
          zlib
        ]
        ++ prev.lib.optionals (!prev.stdenv.isDarwin) [
          imap
        ]
      )
    );

  php74 = prev.php74.override {
    inherit packageOverrides;
  };

  php80 = prev.php80.override {
    inherit packageOverrides;
  };

  php81 = prev.php81.override {
    inherit packageOverrides;
  };
}
