namespace Scale\Kernel\Core;

/**
 * Scale Application
 *
 * @package    Kernel
 * @category   Base
 * @author     Scale Team
 */

use Scale\Kernel\Interfaces\ExecutorInterface;

class Application
{
    protected executor;

    /**
     *
     * @param ExecutorInterface executor
     */
    public function __construct(<ExecutorInterface> executor)
    {
        // Use Builder to find executor for the given client
        let this->executor = executor;
    }
    
    /**
     * Execute the application handler
     */
    public function execute()
    {
        this->executor->prepare()->execute();
    }

    public function say(var text)
    {
        echo text;
    }
}
