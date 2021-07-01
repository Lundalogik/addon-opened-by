import os
import click
import sys
import requests
import re
import subprocess


@click.group()
def cli():
    pass


@cli.command()
@click.argument('repository')
@click.argument('version')
def set_env_from_gh_release_api(repository, version):
    """
        Set the following ENV VARIABLES is gh-actions env
        => RELEASE_UPLOAD_URL
    """
    def _get_dispatch_token():
        token = os.environ.get('DISPATCH_TOKEN', None)
        if not token:
            click.echo("DISPATCH_TOKEN token variable is missing")
            sys.exit(1)
        return token

    def _set_env(name, value):
        cmd = 'echo "' + name + '=' + value + '" >> $GITHUB_ENV'
        subprocess.call(cmd, shell=True)

    dispatch_token = _get_dispatch_token()
    headers = {"Authorization": f"token {dispatch_token}"}
    url = f"https://api.github.com/repos/Lundalogik/{repository}/releases/tags/v{version}"  # noqa
    response = requests.get(url, headers=headers)
    response.raise_for_status()

    data = response.json()
    _set_env('RELEASE_UPLOAD_URL', data['upload_url'])


@cli.command()
@click.argument('release_notes')
def update_docs_changelog(release_notes):
    """
        Parsing release notes and update docs/changelog.md file
    """

    def _format_release_version():
        first_line = release_notes.splitlines()[0]

        # Fetch release version from first line in release note
        match = re.search(r"\[([\d.\d.\d]+)\]", first_line)
        if match:
            return f"## v{match.group(1)}\n\n"

        return "## unknown version\n\n"

    def _format_release_date():
        first_line = release_notes.splitlines()[0]

        # Fetch release date from first line in release note
        match = re.search(
            r"([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))",
            first_line)
        if match:
            return f"**Released:** {match.group(1)}"

        return "**Released:** unknown date"

    def _format_release_notes():
        tail = release_notes.split("\n", 1)[1]

        # Strip injected links
        matches = [x.group for x in re.finditer(r"\(\[(.*)\]\((.*)\)\)", tail)]
        for match in matches:
            tail = tail.replace(match(), "")

        # Strip trailing space on each row
        tail = tail.replace(" \n", "\n")

        # Strip trailing new lines at end of string
        tail = tail.rstrip("\n")

        return f"{tail}\n"

    def _format_new_release():
        """
            Desired format =>

                ## VERSION

                **Released:** DATE

                ### Bug Fixes

                * FIX_ONE
                * FIX_TWO

                ### FEATURES

                * FEAT_ONE
                * FEAT_TWO
        """
        return (f"{_format_release_version()}"
                f"{_format_release_date()}"
                f"{_format_release_notes()}")

    with open("docs/changelog.md", "r") as original_file:
        old_releases = ""

        if original_file.read(1):
            original_file.seek(0)

            lines = original_file.readlines()
            if len(lines) > 1:
                lines.pop(0)
                old_releases = ''.join(lines)

    with open('docs/changelog.md', 'w') as modified_file:
        title = "# Changelog\n\n"
        new_release = _format_new_release()

        modified_file.write(title)
        modified_file.write(new_release)
        modified_file.write(old_releases)


if __name__ == '__main__':
    cli()
