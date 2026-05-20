import pandas as pd
from pathlib import Path
def main():
    Path('/opt/ml/processing/output/train').mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame({'f1':[0,1,0,1],'f2':[0.1,0.2,0.3,0.4],'y':[0,1,0,1]})
    df.to_csv('/opt/ml/processing/output/train/train.csv', index=False)
if __name__ == '__main__':
    main()
