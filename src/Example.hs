module Example where

data Example = Example
  { name :: Text
  , age :: Int
  }
  deriving stock (Show, Eq)
