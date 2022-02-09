for DEPENDENCY in $(cat Mintfile | grep "@" | cut -d "@" -f 1); do
	echo "# $(curl -s https://api.github.com/repos/$DEPENDENCY | jq '.description')" | sed 's/\"//g' >> Mintfile.new;
	TAG=$(curl -s https://api.github.com/repos/$DEPENDENCY/releases/latest | jq '.tag_name')
	echo "$DEPENDENCY@$(curl -s https://api.github.com/repos/$DEPENDENCY/releases/latest | jq '.tag_name')" | sed 's/\"//g' >> Mintfile.new; 
	echo "$(cat Mintfile | grep $DEPENDENCY) is now using $TAG"
	echo ""  >> Mintfile.new; 
done;

mv Mintfile.new Mintfile