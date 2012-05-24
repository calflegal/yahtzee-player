require 'pp'

def getcounts(roll)
  count = [roll.grep(1).size, roll.grep(2).size,
                roll.grep(3).size,roll.grep(4).size,
                roll.grep(5).size, roll.grep(6).size]
    return count
end
def n1(roll)
   return roll.grep(1).size
end
def n2(roll)
   return (roll.grep(2).size)*2
end
def n3(roll)
   return (roll.grep(3).size)*3
end
def n4(roll)
   return (roll.grep(4).size)*4
end
def n5(roll)
   return (roll.grep(5).size)*5
end
def n6(roll)
   return (roll.grep(6).size)*6
end
def threek(roll)
  #you get zero if you don't have three!
  if (getcounts(roll).max < 3)
                return 0
  else
  return roll.inject(:+)
  end
end
def fourk(roll)
  #you get zero if you don't have four!
  if (getcounts(roll).max < 4)
                return 0
  else
  return roll.inject(:+)
  end
end
def house(roll)
  if (getcounts(roll).sort[-1] == 3) && (getcounts(roll).sort[-2] == 2)
    return 25
  else
    return 0
  end
end
def chance(roll)
  return roll.inject(:+)
end
def small(roll)
  if (roll.include?(1) && roll.include?(2) && roll.include?(3) && roll.include?(4)) ||
     (roll.include?(2) && roll.include?(3) && roll.include?(4) && roll.include?(5)) ||
     (roll.include?(3) && roll.include?(4) && roll.include?(5) && roll.include?(6))
    return 30
  else
    return 0
  end
end
def large(roll)
  if roll.sort == ([1,2,3,4,5]) || roll.sort == [2,3,4,5,6]
    return 40
  else
    return 0
  end
end
def yahtzee(roll)
  if getcounts(roll).include?(5)
    return 50
  else
    return 0
  end
end
def upperbonus(scoreboard)
  if ((scoreboard["n1"] + scoreboard["n2"] + scoreboard["n3"] + scoreboard["n4"] + scoreboard["n5"] + scoreboard["n6"]) >= 63)
    return 36
  else return 0
  end
end
def score(scoreboard)
  score = 0
  scoreboard.each do |k,v|
    score = score + v
  end
  score = score + upperbonus(scoreboard)
  return score
end
#begin methods for AI
def scorelist(roll)
  #return a hash that shows all the possible scores for these dice, sorted
  categories = ['yahtzee','fourk','house','threek', 
    'n6', 'n5', 'n4', 'n3', 'n2', 'n1', 'small' ,'large', 'chance']
  scores = {}
  categories.each do |entry|
      #populate the hash
      scores[entry] = eval("#{entry}(#{roll})")
  end
  return scores.sort_by{|k,v| v}.reverse
end
def maxscorelist(roll)
  scorelist(roll).group_by {|k,v| v}.max.last
end
def maxscore(roll)
  maxscorelist[0][1]
end
def bigmovepossible(roll, scoreboard)
  if yahtzee(roll) == 50 && scoreboard["yahtzee"].nil?
    return true
  elsif large(roll) == 40 && scoreboard["large"].nil?
    return true
  else
    return false
  end
end
def makebigmove(roll, scoreboard)
  #a "big move" is yahtzee or large straight (can't be improved via exchange)
  scoreboard[maxscorelist(roll)[0][0]] = maxscorelist(roll)[0][1]
  return [scoreboard, maxscorelist(roll)[0][0]] 
end
def takebestscore(roll, scoreboard)
  #this method needs improvement for choosing a zero (if it comes to that). Truly, we should take a zero in yahtzee early to max score
  scorelist(roll).each do |categoryandscore|
    this_score = categoryandscore[1]
    this_category = categoryandscore[0]
    if scoreboard[this_category].nil?
      movemade = categoryandscore[0]
      scoreboard[movemade] = this_score
      return [scoreboard, movemade ]
    else
      next
    end
  end
end
def tryimprovedice(rollandindex, nextroll, rollnumber, scoreboard)
  #this is the main brain of the AI
  #return the roll AND index format (we gotta keep track of indices)
  roll = rollandindex[0]
  index = rollandindex[1]
  #first, let's look for three of a kind in this set.
  if getcounts(roll).max >= 3
    thenum = getcounts(roll).index(getcounts(roll).max)+1
    #todrop are the values to drop, but not their indicies
    todrop = roll - [thenum]
    #Don't trash a full house! Although we do if we already have one!
    if todrop.length == 2 && (todrop[0] == todrop[1]) && (scoreboard["house"].nil?)
      return rollandindex
    end
   #indexes of ones todrop
   indexes =  todrop.collect { |num| roll.index(num)}
   # geturn the newly swapped dice, roll and index format
   return getnextdice(rollandindex,indexes, nextroll, rollnumber)
   
   
   
  else
    #get a whole new set
     return getnextdice(rollandindex,[0,1,2,3,4], nextroll, rollnumber)
  end
end
def getnextdice(rollandindex,index_swap_array,nextroll,rollnumber)
  #This method takes the current hand in and swaps out the dice you wanna re-roll (index_swap_array)
  roll = rollandindex[0]
  rollindices = rollandindex[1]
  #update roll
  for i in 0..roll.length-1
    if index_swap_array.include?(i)
      roll[i] = nextroll[i]
    end
  end
  #update index
  index_swap_array.each do |swapindex|
    rollindices.collect! do |thisindex|
      if rollindices.index(thisindex) == swapindex
        swapindex + (5*(rollnumber-1)) +1
      else
        thisindex
      end
    end
  end #end iteratiion over swap array
  rollandindex = [roll, rollindices]
 return rollandindex
end
  #main logic
gamelist = Dir.glob('*.rolls')
# play the game for every .rolls
gamelist.each do |filename|
  yahtzeefile = "#{filename[0..-7]}" + ".yahtzee"
  File.open(filename, 'r') do |file|
    categories = ['yahtzee','fourk','house','threek', 
      'n6', 'n5', 'n4', 'n3', 'n2', 'n1', 'small' ,'large', 'chance']
      #start with a fresh (empty)scoreboard
    scoreboard = Hash.new
    categories.each do |category|
      scoreboard[category] = nil
    end
    #begin gameplay
    13.times {
       alldice = file.gets.chomp.split(' ').map!{|numstring| numstring.to_i}
       firstfive = alldice.slice(0..4)
       secondfive = alldice.slice(5..9)
       thirdfive = alldice.slice(10..14)
       currentdice = [firstfive, [1,2,3,4,5]]
       rollnumber = 1
       currentroll = currentdice[0]
       currentindices = currentdice[1]
       #we will duck out early if we can't do better. We DON'T employ for loop because of the use of next in this stuff. Maybe could be cleaner
       if bigmovepossible(currentroll, scoreboard)
         #Note that next will skip the rest of the code for this turn
         # pp "making big move"
          scoreboardandmove = makebigmove(currentroll, scoreboard)
          #The turn will end here, so we must write to the file
          scoreboard = scoreboardandmove[0]
          thismove = scoreboardandmove[1]
          File.open(yahtzeefile, 'a') do |file2|
               file2.puts "#{currentroll} ; #{currentindices}; #{thismove}; #{scoreboard[thismove]} "
          end
         next
       end
       rollnumber = 2
       currentdice = tryimprovedice(currentdice, secondfive, rollnumber, scoreboard)
       currentroll = currentdice[0]
       currentindices = currentdice[1]
       if bigmovepossible(currentroll,scoreboard)
         #Note that next will skip the rest of the code for this turn
         #pp "making big move"
         scoreboardandmove = makebigmove(currentroll, scoreboard)
         #The turn will end here, so we must write to the file
         scoreboard = scoreboardandmove[0]
         thismove = scoreboardandmove[1]
         File.open(yahtzeefile, 'a') do |file2|
              file2.puts "#{currentroll} ; #{currentindices}; #{thismove}; #{scoreboard[thismove]} "
         end
         next
       end
       rollnumber = 3
       currentdice = tryimprovedice(currentdice,thirdfive, rollnumber, scoreboard)
       currentroll = currentdice[0]
       currentindices = currentdice[1]
       # pp "final dice #{currentroll} + and indices #{currentdice[1]}"
       scoreboardandmove = takebestscore(currentroll, scoreboard)
       ##The turn will end here, so we must write to the file
       thismove = scoreboardandmove[1]
       scoreboard = scoreboardandmove[0]
       # pp "#{thismove} was this move"
       ##here we will add to the yahtzee file with same name as rolls, adding the choices for each turn (scoreboard, current roll and indicies)
       File.open(yahtzeefile, 'a') do |file2|
            file2.puts "#{currentroll} ; #{currentindices}; #{thismove}; #{scoreboard[thismove]} "
       end
    }
    File.open(yahtzeefile, 'a') do |file2|
         file2.puts "Score: #{score(scoreboard)}"
    end
    #here we will open the yahtzee fie once more to print the total score
  end #end of one file (game)
end #end of all files
