waiting := model.initial()
visited := model.initial()

while not(waiting.isEmpty()) do
	s := waiting.head()
	waiting := waiting.remove(s)
	//  Handle s here
	for all b enabled in s do
		ss := s.execute(b)
		if not (visited.contains(s)) then
			waiting := waiting.add(ss)
			visited := visited.add(ss)
		endif
	endfor
endwhile
