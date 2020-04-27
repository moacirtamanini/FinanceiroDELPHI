<?php namespace EPlacas\Pessoa;

use EPlacas\Model;
use Illuminate\Database\Eloquent\SoftDeletingTrait;

class Sexo extends Model
{
    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Sexo';

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

    protected $guarded = array('description');

    /**
     * Regras para validação
     * @var array
     */
    public function storeRules()
    {
        return array(
        'descricao' => 'required|between:3,50',
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

    public static function name()
    {
        return 'Sexo';
    }

    public function getDescriptionAttribute()
    {
        return $this->attributes['descricao'];
    }

    /**
     * Sexo pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function pessoa()
    {
        return $this->belongsTo('Pessoa', 'Id');
    }
}
