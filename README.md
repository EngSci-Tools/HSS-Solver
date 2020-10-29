# Square Hollow Structural Section Solver
Instead of looking at a giant table of HSSs, use a computer to do it. Actually, why are you solving struts in the first place? Computers can do it faster and better.

## Usage
When a HSS has been filtered out, it will appear as grey in the table on the right. At that point, it will not be used for calculating the optimal HSS.
| ![Filters](https://i.imgur.com/06ivsu1.png) | If you already have the values for minimum area, I, and radius of gyration you can input them here and they the HSSs will be filtered based on these values. |
---|---
| ![Computing](https://i.imgur.com/96wEQvs.png) | If you do not have your minimum values, you can compute them by inputting your internal strain and, if you are in compression, your member length. Your minimum values will automatically be populated with slide-rule precision. The values are computed as follows: <br/><br/> ![Area Expression](https://latex.codecogs.com/svg.latex?%5Ctext%7BArea%7D_%7Bmin%7D%3D%5Cfrac%7B%5Ctext%7BFOS%7D%5Ccdot%20%5Ctext%7BForce%7D%7D%7B%5Csigma%7B%7D_%7Byield%7D%7D) <br/> ![I Expression](https://latex.codecogs.com/svg.latex?I_%7Bmin%7D%3D%5Cfrac%7B%5Ctext%7BFOS%7D%5Ccdot%20%5Ctext%7BForce%7D%5Ccdot%20%5Ctext%7BLength%7D%5E2%7D%7B%5Cpi%5E2%5Ccdot%20E%7D) <br/> ![Radius Expression](https://latex.codecogs.com/svg.latex?%5Ctext%7BRadius%7D_%7Bmin%7D%20%3D%20%5Cfrac%7B%5Ctext%7BLength%7D%7D%7B200%7D)|
| ![Best Option](https://i.imgur.com/PRKawAC.png) | Once the minimum values are in, the computer filters out all the HSSs that do not meet the minimum values and finds the remaining HSS with the lowest mass. |

## Local Installation
Although you can use the live version at http://hss.engscitools.ca/, you can set up your own development enviroments easily. You just need to have `node` and `npm` installed.

1. Clone the repository with `git clone https://github.com/EngSci-Tools/HSS-Solver`.
1. Navigate into the repository with `cd HSS-Solver`.
1. Install dependencies with `npm install`.
1. Launch the development server with `npm run serve`.
1. Edit the files in the `src` directory.
