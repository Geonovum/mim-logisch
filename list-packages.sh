# Fetch libraries
if [ ! -f "scripts/external-libs/list-packages.xsl" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/list-packages.xsl -o scripts/external-libs/list-packages.xsl
fi

# List packages
java -jar scripts/external-libs/rdf2xml.jar ./model/mim-all.ttl ./media/list-packages.md scripts/external-libs/list-packages.xsl
