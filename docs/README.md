# addon-helpdesk-statistics - Documentation

## The docs
Seeing this file you have successfully generated a documentation template for your Lime Plug or Solution. Great job!
Go through the generated .md files and add your own great documentation. Happy writing, you rock!

## Powered by MkDocs
The documentation is powerd by [MkDocs](https://www.mkdocs.org), a simple Python based documentation tool.
MkDocs takes a bunch of Markdown-files and turn them into beautiful HTML with the help of a config file.

You should now find a `mkdocs.yml` file in your root directory. It is set to use a Lime CRM inspired theme and load
appropriate extensions. If you would like to add more pages or change the names of the exsisting, just modify the `nav`
section in that file.

To build your documentation locally you will need to do the following (requires Python 3.6 or later):

1. Create and then activate a Python venv in your working folder for your git repository.
2. Install dependencies: `pip install -r docs/requirements.txt`
3. Run `mkdocs serve` to start a development server.
4. Browse to the localhost URL supplied to you in the previous step. Everytime you save an .md file in your documentation, the site will be regenerated automatically.

MkDocs can help you output the built HTML to many places. For customer solution we recommend just keeping the generated files,
for add-ons we recommend using `Read the docs`.

If you feel limited by MkDocs you can use Sphinx instead. Sphinx is a very powerful and common way to document Python modules
with deep tie ins to the source code comments.

## Read the docs
We are using the service [Read the Docs](https://readthedocs.com) to generate publicly available documentation. Once set up
Read the Docs will automatically build new versions of the documentation, while still keeping the old versions available!
To get started with Read the Docs, contact IS and they will add your repo.