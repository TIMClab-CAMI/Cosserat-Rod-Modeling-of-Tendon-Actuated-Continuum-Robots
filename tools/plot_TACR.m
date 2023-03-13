function plot_TACR(rX, n_segments, l, n_nodes, approach)

    figure;
    hold on; grid on;
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title(approach);
    for j = 1:n_segments
        range = (j - 1)*n_nodes + 1:j*n_nodes;
        plot3(rX(1, range), rX(2, range), rX(3, range), 'LineWidth', 2);
        plot3(l*ones(size(rX(1, range))), rX(2, range), rX(3, range), ...
                                 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);
        plot3(rX(1, range), l*ones(size(rX(2, range))), rX(3, range), ...
                                 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);
        plot3(rX(1, range), rX(2, range), 0*ones(size(rX(3, range))), ...
                                 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);
    end
    axis equal;
    xlim([-l l]);
    ylim([-l l]);
    zlim([0 1.1*l]);
    view(-35, 20);

end
