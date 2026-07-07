# TODO: Integrate with github actions

# Fetch libraries
if [ ! -d "scripts/external-libs" ]; then
  mkdir -v scripts/external-libs
fi
if [ ! -f "scripts/external-libs/ea2rdf.jar" ]; then
  curl -L -k https://github.com/architolk/ea2rdf/releases/download/v1.3.2/ea2rdf.jar -o scripts/external-libs/ea2rdf.jar
fi
if [ ! -f "scripts/external-libs/rdf2rdf.jar" ]; then
  curl -L -k https://github.com/architolk/rdf2rdf/releases/download/v1.6.0/rdf2rdf.jar -o scripts/external-libs/rdf2rdf.jar
fi
if [ ! -f "scripts/external-libs/rdf2xml.jar" ]; then
  curl -L -k https://github.com/architolk/rdf2xml/releases/download/v1.2.1/rdf2xml.jar -o scripts/external-libs/rdf2xml.jar
fi
if [ ! -f "scripts/external-libs/ea2mim.yaml" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/ea2mim.yaml -o scripts/external-libs/ea2mim.yaml
fi
if [ ! -f "scripts/external-libs/mim2md-new.xsl" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/mim2md-new.xsl -o scripts/external-libs/mim2md-new.xsl
fi
if [ ! -f "scripts/external-libs/mim2dias.xsl" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/mim2dias.xsl -o scripts/external-libs/mim2dias.xsl
fi
if [ ! -f "scripts/external-libs/mim2dia.xsl" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/mim2dia.xsl -o scripts/external-libs/mim2dia.xsl
fi
if [ ! -f "scripts/external-libs/mim2graphml.xsl" ]; then
  curl -L -k https://raw.githubusercontent.com/architolk/mimtools/refs/heads/main/mim2graphml.xsl -o scripts/external-libs/mim2graphml.xsl
fi

# EA omzetten naar MIM
java -jar scripts/external-libs/ea2rdf.jar -sql -ea -e "model/MIM 2.0 - in ontwikkeling.qea" > ./model/mim-ea.ttl
java -jar scripts/external-libs/rdf2rdf.jar -i ./model/mim-ea.ttl -o ./model/mim-all.ttl -c scripts/external-libs/ea2mim.yaml
# Cleanup - only a specific package
java -jar scripts/external-libs/rdf2rdf.jar -i ./model/mim-all.ttl -o ./model/mim.ttl -c scripts/cleanup.yaml
rm ./model/mim-ea.ttl
rm ./model/mim-all.ttl

# Make markdown from MIM
java -jar scripts/external-libs/rdf2xml.jar ./model/mim.ttl ./metamodel-logisch.md scripts/external-libs/mim2md-new.xsl

# All diagrams
java -jar scripts/external-libs/rdf2xml.jar ./model/mim.ttl ./media/diagrams.txt scripts/external-libs/mim2dias.xsl diagrams
while read -r LINE
do
  if [ "${LINE:0:9}" == "urn:uuid:" ]
  then
    java -jar scripts/external-libs/rdf2xml.jar ./model/mim.ttl ./media/mim-edited.graphml scripts/external-libs/mim2dia.xsl ${LINE:0:45}
    java -jar scripts/external-libs/rdf2xml.jar ./model/mim.ttl ./media/${LINE:9:36}.graphml scripts/external-libs/mim2graphml.xsl follow ./media/mim-edited.graphml
  fi
done < ./media/diagrams.txt
rm ./media/diagrams.txt
rm ./media/mim-edited.graphml
