# tsp-practice：可核对、可复现的 GA 与 SA 旅行商实验

这个项目用 MATLAB 实现遗传算法（GA）与模拟退火（SA），研究如何寻找经过所有城市并回到起点的短路径。教学重点是先把目标函数算对，再观察搜索过程，最后比较重复实验。

**本次环境没有 MATLAB，遵照用户要求未安装 MATLAB、Octave 或额外工具。新增 MATLAB 代码和测试完成了静态审查，尚未执行。不能把本文中的预期结果当成已运行结果。**

## 有 MATLAB 时从这里开始

在 MATLAB 中切换到项目根目录，不要使用 `addpath(genpath(pwd))` 将所有参考代码一起加入路径。新入口只依赖基础 MATLAB 功能；没有新增工具箱依赖。目标语法为 MATLAB R2018b 及以上，但版本兼容性尚待实机验证。

```matlab
cd('D:\Projects\tsp-practice')
addpath(fullfile(pwd, 'tests'))
run_tests
result = run_demo(42, false);  % 不弹图、不写文件
result = run_demo(42, true);   % 路线与按评估次数绘制的收敛图
```

正式比较使用一个尚不存在的目录：

```matlab
[runs, summary] = run_experiments(fullfile(pwd, 'results', 'class-01'), 1:10, 2000);
```

输出 `runs.csv`（每次运行）、`summary.csv`（描述性统计）、`experiment.mat`（参数、环境版本、原始数据与历史）。默认每个算法使用 2000 次目标函数评估，既有目录不会覆盖。结果文件只有你实际执行实验后才会产生。

## 从哪读起

1. [目标函数、闭环与 ATT48 距离规则](docs/01-correctness.md)
2. [GA / SA 的步骤、边界与源码导航](docs/02-algorithms.md)
3. [旧入口兼容、历史结果与迁移](docs/03-migration.md)
4. [随机种子、公平比较、测试与后续验收](docs/04-experiments-and-validation.md)

| 目录 / 文件 | 作用 |
| --- | --- |
| `+tsp/` | 唯一的公共距离、路径校验、运算子与求解器实现 |
| `run_demo.m` | 一次可复现的可视化或无界面演示 |
| `run_experiments.m` | 固定预算、多种子、保留每次原始结果 |
| `tests/run_tests.m` | 10 组基础 MATLAB 契约测试，当前未运行 |
| `GeneticAlgorithm/`、`SimulatedAnnealing/` | 保留旧函数名的兼容入口；旧 .mlx/.mat/.txt 为历史材料 |
| `GA_Example/`、`GA_tsp-master/` | 原参考代码，保持原样，不纳入新结果的正确性承诺 |

## 这次修复了什么

- 闭环末边从错误的 `D(N,1)` 改为 `D(route(end),route(1))`。
- ATT48 按 TSPLIB 的伪欧式整数距离计算，不再把未取整距离和标准最优值直接比较。
- 单城市、单个体不再依靠反复抽取两个不同索引，避免死循环。
- GA 从初始种群整体选最优，按准确代数运行，缓存已有目标值；SA 缓存当前长度并处理温度下溢。
- 给种子、参数、排列合法性和评估预算明确契约，结果可追溯。
- 数据加载返回坐标，不再 `clear all` 或悄悄覆盖 cities.mat。

旧入口调用形状仍可使用，例如 `GA_TSP(coords,100,50,.9,.2)` 和 `SA_TSP(coords,1000,.95,100,100)`；增加的第六个可选参数与第三个输出见文档。距离规则和随机运算子修复会改变数值及随机轨迹，旧统计需要重算。

没有替换 MATLAB 技术栈，也没有执行或推送远端实验。本次新增说明不改变原参考代码与数据的许可状态。
