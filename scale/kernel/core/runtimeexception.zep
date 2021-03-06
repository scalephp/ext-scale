namespace Scale\Kernel\Core;

/**
 * Runtime Exception
 *
 * @package    Kernel
 * @category   Base
 * @author     Scale Team
 */

class RuntimeException extends \Exception
{
    public static function handler(var $e)
    {
        string msg;
        let $msg = $e->getMessage().PHP_EOL.$e->getTrace().PHP_EOL;

        fwrite(STDOUT, $msg);
        fwrite(STDERR, $msg);

        throw $e;
    }
}
