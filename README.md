# Cosserat Rod Modeling of Tendon Actuated Continuum Robots

## This code is associated to the following paper, which we request to be explicitly cited in all forms of communication of your work:

> Matthias Tummers, Vincent Lebastard, Frédéric Boyer, Jocelyne Troccaz, Benoît Rosa, and M. Taha Chikhaoui (2023): “Cosserat Rod Modeling of Continuum Robots from Newtonian and Lagrangian Perspectives”. IEEE Transactions on Robotics, 39(3): 2360-2378. DOI: 10.1109/TRO.2023.3238171

It models tendon actuated continuum robots (TACRs) through both the Newtonian and Lagrangian approaches. Compared to other references from the literature, both approaches are extended with novelties. The numerical implementation of the Newtonian approach features a tendon slope discontinuity term, allowing to model robots that involve such discontinuities. In the Lagrangian approach, the numerical resolution is performed through a linearization of the nonlinear static balance equations, which enables to use Newton-Raphson’s method (compared to the explicit time integration of an overdamped equivalent system in other references). Efficient spectral methods are used to calculate the residual vector and the Jacobian matrix thanks to a new boundary value problem (BVP), called the inverse kineto-static BVP, and its tangent BVP. For more details, please refer to the paper available at: https://hal.science/hal-03935561/ .

![helical15](https://user-images.githubusercontent.com/122893979/213212104-5cdcdc3c-d732-45ea-a963-83f159c2a799.png)

## Structure of the code
* The entry-point of the code repository is the "main.m" script that reproduces the results from the associated paper (see above).
* The "tools" folder contains various general order tools regarding Lie algebra, Chebyshev grids, Legendre polynomials, spectral integration, quaternion operations, saving, reading, plotting results, etc.
* Simulation results are saved to the "simulation_results" folder. The simulation result files should be read with the "read_result_N.m" or "read_result_L.m" (files/) functions for simulation results obtained with the Newtonian and Lagrangian approaches, respectively.

## Prerequisites
* MATLAB

## License
This project is licensed under the GPL v3.0 License - see the [LICENSE](https://github.com/TIMClab-CAMI/Cosserat-Rod-Modeling-of-Tendon-Actuated-Continuum-Robots/blob/main/LICENSE) file for details.

## Contributing
Feel free to submit pull requests and use the issue tracker to start a discussion about any bugs you encounter. Please provide a description of your MATLAB version and operating system for any software related bugs.

## Acknowledgements
This work was supported by grants ANR-11-LABX-0004-01, ANR-19-P3IA-0003, ANR-20-CE33-0001, ANR-10-IAHU-0002, and ANR-18-CE19-0012.

