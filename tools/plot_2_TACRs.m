function plot_2_TACRs(r1, r2)

    n_sectinos = length(r1)/300;
    rangeX = 1 + n_sectinos*000:n_sectinos*100;
    rangeY = 1 + n_sectinos*100:n_sectinos*200;
    rangeZ = 1 + n_sectinos*200:n_sectinos*300;
    plot3(r1(rangeX), r1(rangeY), r1(rangeZ), 'LineWidth', 2);
    plot3(r2(rangeX), r2(rangeY), r2(rangeZ), '--', 'LineWidth', 2);
    % legend('Newtonian', 'Lagrangian')

end
