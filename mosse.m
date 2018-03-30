%data_path should include 'img'(including all the frames in a certain sequence) and roundtruth_rect.txt
data_path = './Basketball';

%sequence_path, namely 'img', should include all the frames of a certain sequence
sequence_path = [data_path '/img/'];
sequence_path_dir = dir(sequence_path);

%read the exact position and size [x y w h] of the target in the first frame from groundtruth_rect.txt
%file = fopen([data_path '/groundtruth_rect.txt']);
%ground_truth = textscan(file, '%f,%f,%f,%f');
%fclose(file);
ground_truth = [198 214 34 81];

%save the names of frames in 'img' on frame_name_content
frame_name_content = cell(length(sequence_path_dir) - 2,1);
for i = 1 : (length(sequence_path_dir) - 2)
	frame_name_content{i} = sequence_path_dir(i + 2).name;
end

%read the first frame
first_frame = imread([sequence_path frame_name_content{1}]);
%first_frame = imread('./Basketball/img/0001.jpg');
%turn rgb to gray
if size(first_frame,3) > 1
		first_frame = rgb2gray(first_frame);
end
%target_sz = [w h], which denote the width and height, respectively.
target_sz = [ground_truth(4), ground_truth(3)];
%target_pos = [y x], which denote the position of target's central point, respectively.
target_pos = [ground_truth(2), ground_truth(1)] + floor(target_sz/2);

%ideal gaussian template
gauss_response = gaussian_template(target_sz, first_frame);

update_visualization = show_video(frame_name_content, sequence_path);%%%%%%%%%%%%%%%%%%%

for n = 1 : 725%length(sequence_path)
	%read the n th frame into 'frame'
	frame = imread([sequence_path frame_name_content{n}]);
    %turn rgb to gray
    if size(frame,3) > 1
		frame = rgb2gray(frame);
    end
	%get the subwindow at the target position of last frame
	target_last_frame = get_subwindow(target_pos, target_sz, frame);
	
	if n > 1
		%calculate response of the classifier at all locations
		response = real(ifft2(H .* fft2(target_last_frame)));   
		
		%target location is at the maximum response
		[row, col] = find(response == max(response(:)), 1);
		target_pos = target_pos - floor(target_sz/2) + [row, col];
	end
	
	F = fft2(get_subwindow(target_pos, target_sz, frame));
	H = conj(F.*conj(gauss_response)./F.*conj(F));
	
	%visualization
% 	rect_position = [target_pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
% 	if n == 1  %first frame, create GUI
% 		%figure('Number','off', 'Name','tracker');
%         figure('Name','tracker');
% 		im_handle = imshow(frame, 'Border','tight', 'InitialMag',200);
% 		rect_handle = rectangle('Position',rect_position, 'EdgeColor','g');
% 	else
% 		try  %subsequent frames, update GUI
% 			set(im_handle, 'CData', frame)
% 			set(rect_handle, 'Position', rect_position)
% 		catch  %#ok, user has closed the window
% 			return
% 		end
%     end
    
    %visualization
	box = [target_sz([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
	stop = update_visualization(n, box);
	if stop, break, end  %user pressed Esc, stop early	
	drawnow
% 	pause(0.05)  %uncomment to run slower
end
