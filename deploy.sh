set -e

bash ./buildDocs

git cofig user.name "dreggingames-bot"
git config user.email "dreggongames-bot@mkalte.me"

git clone "https://github.com/DregginGames/Dragon2D" --branch gh-pages pages

rm -rf ./pages/docs
cp -a ./docs ./pages/docs
cd docs
git add .
git commit -m "Automated update of docs"
git push --quiet "https://${GH_TOKEN}@github.com/DregginGames/Dragon2D" gh-pages > /dev/null 2>&1
