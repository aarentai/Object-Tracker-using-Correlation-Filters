function target_box = get_subwindow(target_pos, target_sz, frame)
	%get and process the context region
	xs = floor(target_pos(2)) + (1:target_sz(2)) - floor(target_sz(2)/2);
	ys = floor(target_pos(1)) + (1:target_sz(1)) - floor(target_sz(1)/2);
	
	%check for out-of-bounds coordinates, and set them to the values at
	%the borders
	xs(xs < 1) = 1;
	ys(ys < 1) = 1;
	xs(xs > size(frame,2)) = size(frame,2);
	ys(ys > size(frame,1)) = size(frame,1);	
	%extract image in context region
	target_box = frame(ys, xs, :);	
	%pre-process window
    target_box = double(target_box);
    target_box = (target_box-mean(target_box(:)));%normalization
end