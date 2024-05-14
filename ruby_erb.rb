require 'erb'

meaning_of_life = 42


# <%= ruby code will execute and show output %>
# <% ruby code will execute but not show output %>
question =  "The Answer to the Ultimate Question of Life, the Universe, and Everything is <%= meaning_of_life %>"

template = ERB.new(question)

# binding - returns a special object
results = template.result(binding)

puts results

