
import os, sys

def main():

    # use python 3.9
    assert sys.version_info[:2] == (3,9), "run notebook with python 3.9"

    print("install python packages")
    os.system("pip install -r requirements.txt")

    print("get julia binary")
    os.system("wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.2-linux-x86_64.tar.gz")

    os.system("tar -xf julia-1.9.2-linux-x86_64.tar.gz")

    print("install PyJulia")
    import julia
    julia.install(julia = "/content/julia-1.9.2/bin/julia")

if __name__ == '__main__':
    main()