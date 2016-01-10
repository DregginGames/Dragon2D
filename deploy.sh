set -e

bash ./buildDocs.sh

git config --global user.name "dreggingames-bot"
git config --global user.email "dreggingames-bot@mkalte.me"

git clone "https://github.com/DregginGames/Dragon2D" --branch gh-pages pages

rm -rf ./pages/docs
cp -a ./docs ./pages/docs
cd pages
git add -all .
git commit -m "Automated update of docs"
git push --quiet "https://${GH_TOKEN}@github.com/DregginGames/Dragon2D" gh-pages > /dev/null 2>&1
