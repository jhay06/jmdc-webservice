class TutorialModel:
    def __init__(self,
                 video_id=0,
                 youtube_id=None,
                 video_title=None,
                 youtube_link=None,
                 video_description=None,
                 *args,
                 **kwargs):
        self.video_id=video_id
        self.youtube_id=youtube_id
        self.video_title=video_title
        self.youtube_link=youtube_link
        self.video_description=video_description