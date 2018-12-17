--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative (empty)
import           Data.List (isSuffixOf)
import           Hakyll
import           System.FilePath ( takeBaseName
                                 , takeDirectory
                                 , (</>)
                                 )
import           Text.Pandoc.Options
import           Text.Pandoc.Highlighting (pygments)
--------------------------------------------------------------------------------

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "CNAME" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "404.md" $ do
        route   $ setExtension "html"
        compile $ do
            myPandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    match "index.md" $ do
        route   $ setExtension "html"
        compile $ do
            let indexCtx =
                    constField "description" myDescription <>
                    myContext

            myPandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match (fromList ["cv.md", "work.md"]) $ do
        route   $ cleanRoute
        compile $ myPandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" myContext
            >>= relativizeUrls

    create ["blog/index.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let blogCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Blog"                <>
                    myContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/blog.html" blogCtx
                >>= loadAndApplyTemplate "templates/default.html" blogCtx
                >>= relativizeUrls

    match "posts/*" $ do
        route $ dropPostsPrefix `composeRoutes` dropPostsDate `composeRoutes` cleanRoute
        compile $ myPandocCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    (postCtx)
            >>= loadAndApplyTemplate "templates/default.html" (postCtx)
            >>= relativizeUrls

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = bodyField "description" <>
                          postCtx

            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderAtom myFeedConfiguration feedCtx posts

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = bodyField "description" <>
                          postCtx

            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderRss myFeedConfiguration feedCtx posts

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" <>
    myContext

myContext :: Context String
myContext =
    cleanUrlField "url" <>
    defaultContext

dropPostsDate :: Routes
dropPostsDate = gsubRoute "[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ const ""

dropPostsPrefix :: Routes
dropPostsPrefix = gsubRoute "posts/" $ const ""

-- https://www.rohanjain.in/hakyll-clean-urls/
cleanRoute :: Routes
cleanRoute = customRoute createIndexRoute
    where createIndexRoute ident =
            let p = toFilePath ident
            in takeDirectory p </> takeBaseName p </> "index.html"

cleanIndex :: String -> String
cleanIndex url
    | idx `isSuffixOf` url = take (length url - length idx) url
    | otherwise            = url
    where idx = "index.html"

-- https://inv.alid.pw/posts/hakyll-clean-urls-feeds/
cleanUrlField :: String -> Context a
cleanUrlField key = field key $
    fmap (maybe empty (cleanIndex . toUrl)) . getRoute . itemIdentifier

myPandocCompiler :: Compiler (Item String)
myPandocCompiler = pandocCompilerWith myReaderOptions myWriterOptions

myReaderOptions :: ReaderOptions
myReaderOptions = def
    { readerExtensions = pandocExtensions
    }

myWriterOptions :: WriterOptions
myWriterOptions = def
    { writerExtensions = pandocExtensions
    , writerHighlightStyle = Just pygments
    , writerHTMLMathMethod = MathJax ""
    }

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle = "Brian Buccola"
    , feedDescription = myDescription
    , feedAuthorName = "Brian Buccola"
    , feedAuthorEmail = "brian.buccola@gmail.com"
    , feedRoot = "https://brianbuccola.com/"
    }

myDescription :: String
myDescription = "Brian Buccola is a linguist who specializes in formal and experimental semantics and pragmatics. He also blogs about language, logic, and Linux."
