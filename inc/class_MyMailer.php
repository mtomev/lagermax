<?php
	require_once(COMPS_DIR.'/PHPMailer/PHPMailerAutoload.php');

	class MyMailer extends PHPMailer {
    // Set default variables for all new objects
    public $FromName = "Метро платформа Лагермакс";
    public $Mailer   = "smtp";

		
    public $From     = "metro.platform@lagermax.bg";
    public $Host     = "mail.host.bg";
		public $SMTPAuth = true;
		public $Username = 'metro.platform@lagermax.bg';
		public $Password = '0rtem_Lage6max';

		public $Port = 587;

		// Enable encryption, `tls` `ssl`
		// В момента не работи винаги на host.bg
		//public $SMTPSecure = 'tls';

		//public $SMTPAutoTLS = false;
		public $SMTPAutoTLS = 'ssl';

		public $CharSet = 'UTF-8';
		
    /**
     * SMTP class debug output mode.
     * Debug output level.
     * Options:
     * * `0` No output
     * * `1` Commands
     * * `2` Data and commands
     * * `3` As 2 plus connection status
     * * `4` Low-level data output
     * @var integer
     * @see SMTP::$do_debug
     */
		public $SMTPDebug = 0;

		/*
    'echo' = Output plain-text as-is, appropriate for CLI
    'html' = Output escaped, line breaks converted to <br>, appropriate for browser output
    'error_log' = Output to error log as configured in php.ini
		*/
		public $Debugoutput = 'html';


		public function __construct($exceptions = false) {
			parent::__construct($exceptions);
		}

		public function addAddress($address, $name = '') {
			if (defined('TEST_MAIL_ADDRESS')) {
				$name .= ' <' . $address . '>';
				$address = TEST_MAIL_ADDRESS;
			}
			return parent::addAddress($address, $name);
		}
		
		// extension=php_imap.dll
		public function copyToFolder($folderPath = null) {
			//$message = $this->MIMEHeader . $this->MIMEBody;
			$message = $this->getSentMIMEMessage();
			//$path = "INBOX" . (isset($folderPath) && !is_null($folderPath) ? ".".$folderPath : ""); // Location to save the email
			$path = $folderPath; // Location to save the email
			// IMAP порт 	143
			// IMAP порт за SSL връзка 	993
			$imap_port = ':143';
			$imapStream = imap_open("{" . $this->Host . $imap_port . "}" . $path , $this->Username, $this->Password);
			imap_append($imapStream, "{" . $this->Host . $imap_port . "}" . $path, $message);
			imap_close($imapStream);
		}
	}
?>
