# External packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# Internal code import
import physo
import argparse


parser = argparse.ArgumentParser(description='Dual-pixel based defocus blur synthesis')
parser.add_argument('input_file', help='Input file path')
args = parser.parse_args()


data = pd.read_csv(args.input_file)
z = data['x'].astype(float)
y = data['y'].astype(float)
d = data['fd'].astype(float)
F = data['fs'].astype(float)

X = np.stack((z, d, F), axis=0)

# Running SR task
expression, logs = physo.SR(X, y,
                            # Giving names of variables (for display purposes)
                            X_names = [ "z", "d", "F" ],
                            # Giving units of input variables
                            X_units = [ [1, 0, 0], [1, 0, 0], [1, 0, 0] ],
                            # Giving name of root variable (for display purposes)
                            y_name  = "y",
                            # Giving units of the root variable
                            y_units = [1, 0, 0],
                            # Fixed constants
                            fixed_consts       = [ 1.      ],
                            # Units of fixed constants
                            fixed_consts_units = [ [0,0,0] ],
                            # Free constants names (for display purposes)
                            free_consts_names = [ "a"       , "b"        ],
                            # Units offFree constants
                            free_consts_units = [ [1, 0, 0] , [1, 0, 0] ],
                            # Run config
                            run_config = physo.config.config0.config0,

)

# Inspecting the best expression found
# In ascii
print("\nIn ascii:")
print(expression.get_infix_pretty(do_simplify=True))
# In latex
print("\nIn latex")
print(expression.get_infix_latex(do_simplify=True))
# Free constants values
print("\nFree constants values")
print(expression.free_const_values.cpu().detach().numpy())

# Inspecting pareto front expressions
pareto_front_complexities, pareto_front_expressions, pareto_front_r, pareto_front_rmse = logs.get_pareto_front()
for i, prog in enumerate(pareto_front_expressions):
    # Showing expression
    print(prog.get_infix_pretty(do_simplify=True))
    # Showing free constant
    free_consts = prog.free_const_values.detach().cpu().numpy()
    for j in range (len(free_consts)):
        print("%s = %f"%(prog.library.free_const_names[j], free_consts[j]))
    # Showing RMSE
    print("RMSE = {:e}".format(pareto_front_rmse[i]))
    print("-------------\n")