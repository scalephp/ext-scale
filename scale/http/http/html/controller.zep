namespace Scale\Http\HTTP\HTML;

/**
 * Controller
 *
 */
class Controller
{
    protected view;

    /**
     * 
     */
    public function __construct(<\Closure> view)
    {
        let this->view = view;
    }

    /**
     * 
     * @param string $name
     * @param array $params
     */
    public function renderView($name, $params = [], $ret = false)
    {
        var $view;
        let $view = this->view->__invoke($name, $params);
        
        if ($ret) {
            return $view->render(true);
        }
        
        $view->render();
    }
}
