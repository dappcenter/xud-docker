from tools.core import src


class SourceManager(src.SourceManager):
    def __init__(self):
        super().__init__("https://github.com/connext/rest-api-client")

    def get_ref(self, version):
        if version == "latest":
            return "c7e4f8de58f1b5ee9ae82a3001d65eec894c9fe2"
        elif version == "7.0.0":
            return "5127ad848c3f598a9f23c51dc6d491753740832d"
        elif version == "7.1.0":
            return "26c521ac62181c1d1945a3e252351e24beee8096"
        elif version == "7.1.1":
            return "16fa7aecc19f44dab12e14b9264df63fccb25585"
        elif version == "7.1.2":
            return "c7e4f8de58f1b5ee9ae82a3001d65eec894c9fe2"
