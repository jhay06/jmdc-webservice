import json
import smtplib, ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


class SMTPConfig:
    def __init__(self,
                 smtp_username=None,
                 smtp_password=None,
                 smtp_server=None,
                 smtp_port_tls=0,
                 smtp_port_ssl=0,
                 use_ssl=False,
                 *args, **kwargs
                 ):
        self.smtp_username = smtp_username
        self.smtp_password = smtp_password
        self.smtp_server = smtp_server
        self.smtp_port_tls = smtp_port_tls
        self.smtp_port_ssl = smtp_port_ssl
        self.use_ssl = use_ssl


class SendMail:
    def __init__(self,
                 subject=None,
                 message=None,
                 from_addr=None,
                 to_addr=None,
                 is_html=False,
                 config=None
                 ):
        self.subject = subject
        self.message = message
        self.from_addr = from_addr
        self.to_addr = to_addr
        self.is_html = is_html
        self.is_connected = False
        self.has_valid_config = False
        self.smtp = None
        if config is not None:
            path = 'configs/' + config
            f = open(path)
            data = f.read()
            f.close()
            if data is not None:
                try:
                    self.smtp = SMTPConfig(**json.loads(data))
                    self.has_valid_config = True
                except:
                    self.has_valid_config = False

    def send(self):
        if self.has_valid_config:
            server = None
            if self.smtp.use_ssl:
                print('use of ssl')

                context = ssl.create_default_context()
                server = smtplib.SMTP_SSL(self.smtp.smtp_server,
                                          self.smtp.smtp_port_ssl,
                                          context=context
                                          )

            else:
                print('no ssl')
                server = smtplib.SMTP(self.smtp.smtp_server,
                                      self.smtp.smtp_port_tls)
                server.ehlo()
                server.starttls()
            if server is not None:
                login = server.login(self.smtp.smtp_username, self.smtp.smtp_password)
                if login:
                    self.is_connected = True
                    me = self.from_addr
                    you = self.to_addr

                    if self.is_html:
                        msg = MIMEMultipart('alternative')
                        msg['Subject'] = self.subject
                        msg['From'] = me
                        msg['To'] = you

                        msg.attach(MIMEText(self.message, 'html'))
                        server.sendmail(me, you, msg.as_string())
                        server.quit()
                        return True
                    else:
                        server.sendmail(me, you, 'Subject: {}\n\n{}'.format(self.subject, self.message))
                        server.quit()
                        return True
                else:
                    return False
            else:
                return False
        else:
            return False
