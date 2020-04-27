<?php namespace EPlacas\Pessoa;

use EPlacas\Model;
use Illuminate\Database\Eloquent\SoftDeletingTrait;

class EstadoCivil extends Model
{
    use SoftDeletingTrait;

    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.EstadoCivil';

    /**
     * Primary key of table
     * @var string
     */
    protected $primaryKey = 'Id';

    /**
     * Campos mass-assigment
     * @var array
     */
    protected $fillable = array('descricao');

    protected $guarded = array('key','description');

    public static function name()
    {
        return 'Estado Civil';
    }

    /**
     * Regras para validação
     * @var array
     */
    public function storeRules()
    {
        return
        array(
        'descricao' => 'min:3|max:50',
        );
    }

    /**
     * Regras para validação de edição
     * @return array
     */
    public function updateRules()
    {
        return $this->storeRules();
    }

    public function getDescriptionAttribute()
    {
        return $this->attributes['descricao'];
    }

    /**
     * EstadoCivil pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function pessoa()
    {
        return $this->belongsTo('EPlacas\Pessoa\Pessoa', 'Id');
    }
}
