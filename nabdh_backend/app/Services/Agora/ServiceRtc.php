<?php

namespace App\Services\Agora;

/**
 * Agora RTC service used inside AccessToken2.
 * Layout: uint16(type) . uint16(count) . [uint16(priv) . uint32(expire)]… . str(channel) . str(uid)
 */
class ServiceRtc
{
    const SERVICE_TYPE = 1;

    // Privilege codes
    const PRIV_JOIN_CHANNEL           = 1;
    const PRIV_PUBLISH_AUDIO_STREAM   = 2;
    const PRIV_PUBLISH_VIDEO_STREAM   = 3;
    const PRIV_PUBLISH_DATA_STREAM    = 4;

    private string $channelName;
    private string $uid;           // empty string means "any uid"
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

    /** @param int $expireSeconds seconds from the token's issue time */
    public function addPrivilege(int $privilege, int $expireSeconds): void
    {
        $this->privileges[$privilege] = $expireSeconds;
    }

    public function pack(): string
    {
        ksort($this->privileges, SORT_NUMERIC);

        $msg = pack('v', $this->getServiceType()) . pack('v', count($this->privileges));
        foreach ($this->privileges as $key => $expire) {
            $msg .= pack('v', $key) . pack('V', $expire);
        }

        return $msg
            . AccessToken2::packString($this->channelName)
            . AccessToken2::packString($this->uid);
    }
}
