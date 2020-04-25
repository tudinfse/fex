class Config:
    """
    A global configuration class
    Based on Borg pattern (similar to Singleton)
    """
    __shared_state = {}

    baseline_subtype: str = "native"
    build_path: str = "./build"
    colored_logs: bool = True

    def __init__(self):
        self.__dict__ = self.__shared_state

    def __str__(self):
        return self.__shared_state
