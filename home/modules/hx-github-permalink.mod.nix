{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.hx-github-permalink = pkgs.callPackage (
        {
          coreutils,
          diffutils,
          jq,
          jujutsu,
          writeShellApplication,
        }:
        writeShellApplication {
          name = "hx-github-permalink";
          runtimeInputs = [
            coreutils
            diffutils
            jq
            jujutsu
          ];
          text = /* bash */ ''
            file="$(realpath -- "''${1:?missing file}")"
            line="''${2:-1}"

            if [[ ! "$line" =~ ^[1-9][0-9]*$ ]]; then
              echo "Expected a positive line number." >&2
              exit 1
            fi

            root="$(realpath -- "$(jj root)")"
            if [[ "$file" != "$root/"* ]]; then
              echo "The file is outside this repository." >&2
              exit 1
            fi

            remote=""
            while read -r remote_name remote_url; do
              if [[ "$remote_name" == origin ]]; then
                remote="$remote_url"
                break
              fi
            done < <(jj git remote list)

            case "$remote" in
              https://github.com/*) repository="''${remote#https://github.com/}" ;;
              git@github.com:*) repository="''${remote#git@github.com:}" ;;
              ssh://git@github.com/*) repository="''${remote#ssh://git@github.com/}" ;;
              *) echo "Origin must be a GitHub repository." >&2; exit 1 ;;
            esac
            repository="''${repository%.git}"
            if [[ ! "$repository" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]; then
              echo "Origin has an invalid GitHub repository path." >&2
              exit 1
            fi

            revision="$(jj log --ignore-working-copy --no-graph \
              --revisions 'latest(remote_bookmarks(remote=exact:origin) & ::@, 1)' \
              --template commit_id)"
            if [[ -z "$revision" ]]; then
              echo "Push a bookmark to origin before creating a permalink." >&2
              exit 1
            fi

            published=$(mktemp)
            trap 'rm --force "$published"' EXIT
            if ! jj file show --revision "$revision" -- "$file" > "$published" 2>/dev/null \
              || ! cmp --silent "$file" "$published"; then
              echo "This file differs from its published version; push it before creating a permalink." >&2
              exit 1
            fi

            relative="''${file#"$root"/}"
            encoded=$(jq --null-input --raw-output --arg value "$relative" '$value | split("/") | map(@uri) | join("/")')
            printf 'https://github.com/%s/blob/%s/%s#L%s' "$repository" "$revision" "$encoded" "$line"
          '';
        }
      ) { };
    };
}
