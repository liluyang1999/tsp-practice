function result = run_demo(seed, showPlot)
%RUN_DEMO One reproducible ATT48 run, without saving or overwriting any files.
if nargin < 1
    seed = 42;
end
if nargin < 2
    showPlot = true;
end
seed = tsp.requireInteger(seed, 'Seed', 0);
if ~islogical(showPlot) || ~isscalar(showPlot)
    error('tsp:PlotOption', 'showPlot must be true or false.');
end
[cities, metadata] = tsp.att48();
options = struct('Seed', seed, 'DistanceType', metadata.DistanceType, 'MaxEvaluations', 2000);
[gaRoute, gaLength, gaInfo] = tsp.ga(cities, 100, 50, .9, .2, options);
[saRoute, saLength, saInfo] = tsp.sa(cities, 1000, .95, 100, 100, options);
result = struct('GA', struct('Route', gaRoute, 'Length', gaLength, 'Info', gaInfo), ...
    'SA', struct('Route', saRoute, 'Length', saLength, 'Info', saInfo), 'Metadata', metadata);
fprintf('ATT48, seed=%u, optimum=%g\n', seed, metadata.Optimum);
fprintf('GA: length=%g, evaluations=%d\n', gaLength, gaInfo.Evaluations);
fprintf('SA: length=%g, evaluations=%d\n', saLength, saInfo.Evaluations);
if showPlot
    figure('Name', 'ATT48 teaching demo', 'Color', 'w');
    subplot(1, 2, 1);
    drawRoute(cities, gaRoute, sprintf('GA: %g', gaLength));
    subplot(1, 2, 2);
    drawRoute(cities, saRoute, sprintf('SA: %g', saLength));
    figure('Name', 'Best-so-far objective', 'Color', 'w');
    stairs(gaInfo.EvaluationHistory, gaInfo.BestHistory, 'LineWidth', 1.5);
    hold on;
    stairs(saInfo.EvaluationHistory, saInfo.BestHistory, 'LineWidth', 1.5);
    xlabel('Objective evaluations'); ylabel('ATT tour length');
    legend('GA', 'SA'); grid on;
end
end

function drawRoute(cities, route, label)
closed = [route route(1)];
plot(cities(1, closed), cities(2, closed), '-o', 'MarkerSize', 3);
axis equal; grid on;
title(label); xlabel('x'); ylabel('y');
end
