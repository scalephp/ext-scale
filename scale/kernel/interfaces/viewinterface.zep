namespace Scale\Kernel\Interfaces;

interface ViewInterface
{
    public function __construct($name, $params = [], $ns = null);

    public function render($return = true);
}
