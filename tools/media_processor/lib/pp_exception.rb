module PpException

  class UnknownProvider < StandardError
  end

  class CantWriteToFs < StandardError
  end

  class UnknownFolderProcessing < StandardError
  end

  class UnknownFeedType < StandardError
  end
  
  class CantReadMeta < StandardError
  end

  class OlderServerTimeForUpdate < StandardError
  end

  class SaifEmptyPhotographe < StandardError
  end

  class NoReceptionDate < StandardError
  end

  class BadMaxAvailSize < StandardError
  end

  class NotUpdatableFeed < StandardError
  end

  class MsImageIdProblem < StandardError
  end

  class NoMeta < StandardError
  end

end
