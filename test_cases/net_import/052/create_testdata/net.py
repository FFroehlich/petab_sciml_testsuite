"""Neural network import test generation"""

import os
import torch
from torch import nn
from torch.nn import functional as F
from test_cases.net_import.helper import make_yaml, test_nn

class Net(nn.Module):
    def __init__(self) -> None:
        super().__init__()
        self.layer1 = nn.Bilinear(10, 10, 5)
        self.layer2 = nn.Linear(5, 5)
        self.layer3 = nn.Linear(5, 1)

    def forward(self, net_input1: torch.Tensor, net_input2: torch.Tensor) -> torch.Tensor:
        x = self.layer1(net_input1, net_input2)
        x = F.tanh(x)
        x = self.layer2(x)
        x = F.tanh(x)
        x = self.layer3(x)
        return x

# Create a pytorch module, convert it to PEtab SciML, then save it to disk.
dir_save = os.path.join(os.getcwd(), 'test_cases', 'net_import', "052")
net = Net()
make_yaml(net, dir_save)
test_nn(net, dir_save, ["layer1", "layer2", "layer3"], n_input_arguments=2)
