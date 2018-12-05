function colors = distinguishable_colors(n_colors)

colors = zeros(8, 3);
colors(1,:) = [255 0 0]; % red
colors(2,:) = [0 128 0]; % green
colors(3,:) = [0 0 255]; % blue
colors(4,:) = [0 255 255]; % cyan
colors(5,:) = [255 255 0]; % yellow
colors(6,:) = [255 0 255]; % magenta
colors(7,:) = [210 180 140]; % brown
colors(8,:) = [0 0 0];     % black
colors = colors(1:n_colors,:)./255; % constrain to #colors

end

