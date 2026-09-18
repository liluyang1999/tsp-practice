# 旧项目如何迁移，哪些结果不能沿用

基线提交：c9c6937bedc561aa8b991572134176b72f0cbd24。本次保留目录布局、函数名与原始资料，公共逻辑集中到 +tsp/，避免两份 route_length.m 和 dist_mat.m 再次分叉。

## 旧函数还可以怎么调用

从 GeneticAlgorithm/ 或 SimulatedAnnealing/ 调用原函数时，包装入口会临时加入项目根目录，函数退出后恢复原 MATLAB path，包括异常退出。推荐新代码直接使用带包名的 `tsp.ga`、`tsp.sa` 等。

| 原入口 | 当前实现 | 行为变化 |
| --- | --- | --- |
| GA_TSP（原五参数） | tsp.ga | 支持可选 options、第 3 个 info 输出；代数与初始最优修正 |
| SA_TSP（原五参数） | tsp.sa | 支持 options/info；缓存成本、预算、温度边界 |
| route_length | tsp.routeLength | 修复闭环，验证排列与距离矩阵 |
| dist_mat | tsp.distanceMatrix | 默认真实 ATT，可选距离类型 |
| loadatt48 | tsp.att48 | 返回坐标；不 clear all，不隐式保存 cities.mat |
| init_pop / crossover / mutation / tour_select | 对应公共实现 | 单城市/个体终止，交叉保持排列，选择基于缓存长度 |
| cal_fitness | 1/(1+length) | 有限单调分数，零长度不产生 Inf |
| perform_2opt | tsp.reverseSegment | 单城市直接返回 |

新函数报告 tsp: 开头的验证错误。若旧调用提供空数据、重复城市或无效参数，现在会明确失败，而不是产生难以解释的数值。

## 不再靠 loader 的磁盘副作用

旧 Live Script 的 `loadatt48; load cities.mat` 依赖隐式保存，容易读到旧文件。新代码应直接写：

```matlab
cities = tsp.att48();
```

如果你明确需要生成 MAT 文件，应先选择新路径并自行保存；本次的公共加载器不会覆盖原文件。旧 .mlx/.mat 保留原样便于复盘，当前运行入口是根目录两个文本函数。

## 历史材料的含义

GeneticAlgorithm/、SimulatedAnnealing/ 中的 Main.mlx、BestLengthRecords.txt、Avg&Std.txt、cities.mat，以及根目录 Comparison.mlx，均视为原实验档案。旧目标函数末边有误，ATT 距离也未按标准取整，运行中没有记录可重建的种子和统一评估预算。

因此旧均值、方差、收敛图和显著性比较不能继续支撑“当前实现哪个更好”的结论；需要在 MATLAB 中运行新入口重新取得数据。本次没有伪造新统计，也没有覆盖这些历史文件。

Comparison.mlx 使用 signrank，需要相应工具箱。新入口只给出描述性统计，不自动调用 signrank，不安装工具箱。若以后需要假设检验，应先说明样本是否配对、独立性、效应大小和重复比较方法。

GA_Example/ 与 GA_tsp-master/ 属于既有参考代码，来源和许可信息按原仓库保留。本次没有对它们作完整正确性承诺，也不要把它们和 +tsp/ 一起递归加入 path 后混用同名函数。
