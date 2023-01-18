# Cosserat Rod Modeling of Tendon Actuated Continuum Robots

## Warning !
Codes will be released shortly!
Feel free to contact us and we will be happy to share our codes before official release.

## This code is associated to the following paper, which we request to be explicitly cited in all forms of communication of your work:

> Matthias Tummers, Vincent Lebastard, Frédéric Boyer, Jocelyne Troccaz, Benoît Rosa, and M. Taha Chikhaoui, “Cosserat Rod Modeling of Continuum Robots from Newtonian and Lagrangian Perspectives,” IEEE Transactions on Robotics (in press). DOI: 10.1109/TRO.2023.3238171

It models tendon actuated continuum robots through both the Newtonian and Lagrangian approaches. Compared to other references from the literature, both approaches are extended with novelties. The numerical implementation of the Newtonian approach features a tendon slope discontinuity term, allowing to model robots that involve such discontinuities. In the Lagrangian approach, the numerical resolution is performed through a linearization of the nonlinear static balance equations, which enables to use Newton-Raphson’s method (compared to the explicit time integration of an overdamped equivalent system in other references). Efficient spectral methods are used to calculate the residual vector and the Jacobian matrix thanks to a new BVP, called the inverse kineto-static BVP, and its tangent BVP. For more details, please refer to the paper.

![helical15](https://user-images.githubusercontent.com/122893979/213212104-5cdcdc3c-d732-45ea-a963-83f159c2a799.png)


## Prerequisites
* MATLAB

## License
This project is licensed under the GPL v3.0 License - see the [LICENSE](https://github.com/TIMClab-CAMI/Cosserat-Rod-Modeling-of-Tendon-Actuated-Continuum-Robots/blob/main/LICENSE) file for details.

## Contributing
Feel free to submit pull requests and use the issue tracker to start a discussion about any bugs you encounter. Please provide a description of your MATLAB version and operating system for any software related bugs.

## Acknowledgements
This work was supported by grants ANR-11-LABX-0004-01, ANR-19-P3IA-0003, ANR-20-CE33-0001, ANR-10-IAHU-0002, and ANR-18-CE19-0012.

