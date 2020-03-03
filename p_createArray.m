clear
load('SubjectsOdor'); 

for s = 1:size(subjectOdor,2) 
    
    
    d = sprintf('s_%d = subjectOdor{s};',s);
    eval(d);
end

clear subjectFiles s d 
save('SubjectsOdor.mat','-v7.3'); 