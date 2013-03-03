class CrackInterval
   include DRbUndumped

   attr_reader :start,:finish,:length

   def initialize a,b,len
      raise sprintf("start[%d] is less[%d] than end",a,b) unless a <= b

      @start = a
      @finish = b
      @length = len
   end
end