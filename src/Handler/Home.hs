{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
module Handler.Home where

import Import hiding ((==.), id, on)
import Database.Esqueleto
import qualified Data.Text as T
import Text.Julius (RawJS (..))
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)

default (Int, T.Text)

-- Define our data that will be used for creating the form.
data FileForm = FileForm
    { fileInfo :: FileInfo
    , fileDescription :: Text
    }

-- This is a handler function for the GET request method on the HomeR
-- resource pattern. All of your resource patterns are defined in
-- config/routes
--
-- The majority of the code you will write in Yesod lives in these handler
-- functions. You can spread them across multiple files if you are so
-- inclined, or create a single monolithic file.
getHomeR :: Handler Html
getHomeR = do
    (formWidget, formEnctype) <- generateFormPost sampleForm
    let submission = Nothing :: Maybe FileForm
        handlerName = "getHomeR" :: Text
    allComments <- runDB getAllComments

    defaultLayout $ do
        let (commentFormId, commentTextareaId, commentListId) = commentIds
        aDomId <- newIdent
        setTitle "Welcome To Yesod!"
        $(widgetFile "homepage")

postHomeR :: Handler Html
postHomeR = do
    ((result, formWidget), formEnctype) <- runFormPost sampleForm
    let handlerName = "postHomeR" :: Text
        submission = case result of
            FormSuccess res -> Just res
            _ -> Nothing
    allComments <- runDB getAllComments

    defaultLayout $ do
        let (commentFormId, commentTextareaId, commentListId) = commentIds
        aDomId <- newIdent
        setTitle "Welcome To Yesod!"
        $(widgetFile "homepage")

getAllComments :: DB [Entity Comment]
getAllComments = select $
    from $ \comments -> do
    return comments

sampleForm :: Form FileForm
sampleForm = renderBootstrap3 BootstrapBasicForm $ FileForm
    <$> fileAFormReq "Choose a file"
    <*> areq textField textSettings Nothing
    -- Add attributes like the placeholder and CSS classes.
    where textSettings = FieldSettings
            { fsLabel = "What's on the file?"
            , fsTooltip = Nothing
            , fsId = Nothing
            , fsName = Nothing
            , fsAttrs =
                [ ("class", "form-control")
                , ("placeholder", "File description")
                ]
            }

commentIds :: (Text, Text, Text)
commentIds = ("js-commentForm", "js-createCommentTextarea", "js-commentList")

-- Boards

-- Board.all
getAllBoards :: DB [Entity Board]
getAllBoards = select $
  from $ \boards -> do
  return boards

-- boards#index
getBoardsR :: Handler Html
getBoardsR = do
    boards <- runDB getAllBoards
    defaultLayout $ do
        setTitle "All Boards"
        $(widgetFile "boards")

getPostsForBoard :: BoardId -> DB [(Entity Post, Maybe (Entity User))]
getPostsForBoard boardId = select $
  from $ \(posts `LeftOuterJoin` user) -> do
  on $ posts ^. PostAuthorId ==. user ?. UserId
  where_ $ posts ^. PostBoardId ==. val boardId
  return (posts, user)

getBoardR :: BoardId -> Handler Html
getBoardR id = do
    board <- runDB $ get404 id
    posts <- runDB $ getPostsForBoard id
    defaultLayout $ do
        $(widgetFile "board")
