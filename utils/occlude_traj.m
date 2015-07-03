function occluded_traj = occlude_traj(traj, percentage)

% traj vector of  of frame point(x,y) (w,h) x,y center bottom
% percentage on the total traj point completely occluded in the occlusion
% speed type of occlusion multiplier of average target speed vector [vx,vy]
% percentage of reducing BBox in each direction

occl_count  = 0;
t_length    = size(traj, 1);
speed       = [0.5 0.5];

if t_length < 4
    occluded_traj = zeros(size(traj));
    return;
end

% choose occlusion direction
direction   = [1 0];
speed_idx   = speed;

% choose occlusion length
num_point_occ   = min(t_length - 4, round(t_length * percentage));
num_point       = num_point_occ + round(1/min(speed));

% choose the start index of occlusion
start_index     = randi([2 max(2, t_length - num_point - 2)], 1, 1);

% start linear occlusion model
occluded_traj   = traj;
orig_size       = traj(start_index, 4 : 5);

for i = 0 : min(size(traj,1) - start_index - 1, num_point - 2)
    obj = traj(start_index + i, :);
    w   = obj(4);
    h   = obj(5);
    
    % resize bounding box
    rect_center = [obj(2) round(obj(3) + h / 2)];
    if(occl_count < 1)% || occl_count > num_hold)
        new_size = min(orig_size, ...
            abs([w h] - abs(direction) .* speed_idx .* speed .* [w 0]));
        speed_idx = speed_idx + min(speed);
        
        % find new center
        new_center = rect_center;
        if (sum(new_size == orig_size) ~= 2)
            new_center = rect_center + direction .* speed .* [w 0];
        end
    end
    
    % check se troppo piccolo occlusione
    if any(new_size < orig_size / 2)
        new_size    = [0 0];
        occl_count  = occl_count + 1;
    end
    
    new_bottom = [new_center(1) new_center(2) - new_size(2) ./ 2];
    occluded_traj(start_index + i, 2 : 5) = [new_bottom new_size];
end

end


