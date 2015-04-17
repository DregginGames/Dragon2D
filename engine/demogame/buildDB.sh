rm ./*/*.db
for D in *; do
    if [ -d "${D}" ]; then
		cd ${D}
		ls | cat > ${D}.db
		cd ..
	fi
done
sleep 2