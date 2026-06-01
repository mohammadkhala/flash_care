<?php

namespace App\Services\Agora;

/**
 * Agora RTC service used inside AccessToken2.
 * Mirrors the official PHP SDK:
 * https://github.com/AgoraIO/Tools/tree/master/DynamicKey/AgoraDynamicKey/php
 */
class ServiceRtc
{
    const SERVICE_TYPE = 1;

    // Privilege codes
    const PRIV_JOIN_CHANNEL          = 1;
    const PRIV_PUBLISH_AUDIO_STREAM  = 2;
    const PRIV_PUBLISH_VIDEO_STREAM  = 3;
    const PRIV_PUBLISH_DATA_STREAM   = 4;
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

    /** Serialize to binary (little-endian length-prefixed strings, big-endian ints) */
    public function pack(): string
    {
        $msg  = pack('n', $this->getServiceType());
        $msg .= $this->packString($this->channelName);
        $msg .= $this->packString($this->uid);

        ksort($this->privileges);
        $msg .= pack('n', count($this->privileges));
        foreach ($this->privileges as $key => $expire) {
            $msg .= pack('n', $key);
            $msg .= pack('N', $expire);
        }
        return $msg;
    }

    private function packString(string $str): string
    {
        return pack('n', strlen($str)) . $str;
    }
}
