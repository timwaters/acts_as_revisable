module WithoutScope #:nodoc:
  module ActsAsRevisable
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 1
      TINY  = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
