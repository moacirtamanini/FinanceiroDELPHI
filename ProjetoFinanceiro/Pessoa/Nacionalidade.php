<?php namespace EPlacas\Pessoa;

use EPlacas\Model;

class Nacionalidade extends Model
{
    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Nacionalidade';

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

    protected $guarded = array('key',
                               'description',);

    public static function name()
    {
        return 'Nacionalidade';
    }

    public function storeRules()
    {
        return array(
        'descricao'   => 'required|between:3,100',
        );
    }

    public function updateRules()
    {
        return $this->storeRules();
    }

    public function getDescriptionAttribute()
    {
        return $this->attributes['descricao'];
    }

    /**
     * Nacionalidade pertence a um registro de Pessoa
     * @return Pessoa
     */
    public function pessoa()
    {
        return $this->belongsTo('EPlacas\Pessoa\Pessoa', 'Id', 'PessoaId');
    }
}
