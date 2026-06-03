<?php

namespace App\Services\Agora;

/**
 * Agora RTC service used inside AccessToken2.
 * All integers packed little-endian to match the official PHP SDK.
 */
class ServiceRtc
{
    const SERVICE_TYPE = 1;

    // Privilege codes
    const PRIV_JOIN_CHANNEL           = 1;
    const PRIV_PUBLISH_AUDIO_STREAM   = 2;
    const PRIV_PUBLISH_VIDEO_STREAM   = 3;
    const PRIV_PUBLISH_DATA_STREAM    = 4;
    const PRIV_SUBSCRIBE_AUDIO_STREAM = 5;
    const PRIV_SUBSCRIBE_VIDEO_STREAM = 6;
    const PRIV_SUBSCRIBE_DATA_STREAM  = 7;

    private string $channelName;
    private string $uid;           // uid as string; empty string means "any uid"
    private array  $privileges = [];

    public function __construct(string $channelName, int $uid = 0)
    {
        $this->channelName = $channelName;
        $this->uid         = ($uid === 0) ? '' : (string) $uid;
    }

    public function getServiceType(): int
    {
        return self::SERVICE_TYPE;
    }

    public function addPrivilege(int $privilege, int $expireTs): void
    {
        $this->privileges[$privilege] = $expireTs;
    }

    /** Serialize to binary — all little-endian, strings length-prefixed */
    public function pack(): string
    {
        // service type: uint16-LE
        $msg  = pack('v', $this->getServiceType());

        // packString: uint16-LE length + raw bytes
        $msg .= pack('v', strlen($this->channelName)) . $this->channelName;
        $msg .= pack('v', strlen($this->uid))         . $this->uid;

        ksort($this->privileges, SORT_NUMERIC);
        $msg .= pack('v', count($this->privileges));   // uint16-LE count
        foreach ($this->privileges as $key => $expire) {
            $msg .= pack('v', $key);     // privilege code: uint16-LE
            $msg .= pack('V', $expire);  // expire timestamp: uint32-LE
        }
        return $msg;
    }
}
