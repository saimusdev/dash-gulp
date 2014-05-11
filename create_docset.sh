#!/bin/bash --
DOCSET_NAME="Gulp"
DOCUMENTATION_SRC="https://github.com/gulpjs/gulp/"

# CREATE THE DOCSET FOLDER...
echo -e "$(tput setaf 2)--> Creating the folder structure$(tput sgr0)"
test -d ${DOCSET_NAME}.docset/Contents/Resources  && rm -rf ${DOCSET_NAME}.docset/Contents/Resources 2>/dev/null >&2
mkdir -p ${DOCSET_NAME}.docset/Contents/Resources/Documents
cp icon.tiff ${DOCSET_NAME}.docset/

#  DOWNLOAD THE DOCSET...
echo -e "$(tput setaf 2)--> Downloading the documentation of '$DOCSET_NAME'$(tput sgr0)"
git clone $DOCUMENTATION_SRC

mkdir -p gulp_docs && mv gulp/docs/* gulp_docs
cp style.css ${DOCSET_NAME}.docset/Contents/Resources/Documents/
mv gulp_docs/* ${DOCSET_NAME}.docset/Contents/Resources/Documents/
cd ${DOCSET_NAME}.docset/Contents/Resources/Documents/

for inputFile in `find . -type f \( -iname "*.md" \)`; do
	strippedName=${inputFile%.*}
	fullName="${strippedName#./}.html"
	shortName=${strippedName##*/}
	touch $fullName
	echo $fullName
	# Head
	cat >> "$fullName" << HEAD
<!DOCTYPE html>
<html lang="es">
<head>
	<title>$shortName</title>
    <meta charset="utf-8">
	<link rel="stylesheet" href="style.css" />
</head>
<body>
HEAD
	
	# HTML Content
	cat $inputFile | markdown >> $fullName
	
	# Tail
	cat >> "$fullName" << TAIL
</body>
</html>
TAIL
	
	rm -f $inputFile
done
cd ../../../..

# CLEAN
rm -rf gulp gulp_docs


#  CREATE PROPERTY LIST...
echo -e "$(tput setaf 2)--> Creating the Property List$(tput sgr0)"
cat > "${DOCSET_NAME}.docset/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>$DOCSET_NAME</string>
	<key>CFBundleName</key>
	<string>$DOCSET_NAME</string>
	<key>DocSetPlatformFamily</key>
	<string>$DOCSET_NAME</string>
	<key>isDashDocset</key>
	<true/>
	<key>dashIndexFilePath</key>
	<string>index.html</string>
	<key>isJavaScriptEnabled</key>
	<true/>
</dict>
</plist>
EOF
echo "$(tput setaf 2)Created 'Info.plist'$(tput sgr0)"

# PARSE & CLEAN THE HTML DOCUMENTATION. FILL THE DB...
#echo -e "$(tput setaf 2)--> Parsing the documentation...$(tput sgr0)"
#php phalcon_parser.php $DOCSET_NAME ${DOCSET_NAME}.docset/Contents/Resources/Documents


# OPEN THE DOCSET
if [ -d "$HOME/Library/Application Support/Dash/Docsets" ]; then
	exit 0
	#mkdir -p "$HOME/Library/Application Support/Dash/Docsets/$DOCSET_NAME"
	#mv -f "${DOCSET_NAME}.docset" "$HOME/Library/Application Support/Dash/Docsets/$DOCSET_NAME/"
	#open -a "/Applications/Dash.app" $HOME/Library/Application\ Support/Dash/Docsets/${DOCSET_NAME}/${DOCSET_NAME}.docset
fi
